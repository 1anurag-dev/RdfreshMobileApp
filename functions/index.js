const admin = require("firebase-admin");
const {logger} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

admin.initializeApp();

const db = admin.firestore();

// ─── Push Notification Trigger ───────────────────────────────────────────────

exports.sendNotification = onDocumentCreated("notifications/{id}", async (event) => {
  const data = event.data.data();
  const userId = data.notifyTo;

  try {
    const userDoc = await db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      logger.error(`No token found for user ${userId}`);
      return;
    }

    const message = {
      notification: {
        title: data.title,
        body: data.message,
      },
      data: {
        orderId: data.orderId || "",
        type: data.type || "alert",
      },
      token: fcmToken,
    };

    await admin.messaging().send(message);
    logger.info(`Notification sent to user: ${userId}`);
  } catch (error) {
    logger.error("Failed to send notification:", error);
  }
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

async function getConfig() {
  const configDoc = await db.collection("settings").doc("config").get();
  if (!configDoc.exists) {
    throw new HttpsError("not-found", "Settings config not found");
  }
  return configDoc.data();
}

async function getQuickBooksSettings() {
  const [configDoc, qbDoc] = await Promise.all([
    db.collection("settings").doc("config").get(),
    db.collection("settings").doc("quickbooks").get(),
  ]);

  if (!configDoc.exists || !qbDoc.exists) {
    throw new HttpsError("not-found", "QuickBooks settings not found");
  }

  const config = configDoc.data();
  const qb = qbDoc.data();
  const tokens = qb.tokens || {};

  return {
    accessToken: tokens.access_token || "",
    refreshToken: tokens.refresh_token || "",
    realmId: qb.realmId || "",
    clientId: config.QB_clientId || "",
    clientSecret: config.QB_SKId || "",
    redirectUri: config.QUICKBOOKS_REDIRECT_URI || "",
    isProduction: false,
  };
}

async function ensureValidQBToken(settings) {
  // Always refresh to be safe (tokens stored without reliable expiry tracking)
  const authHeader = "Basic " +
    Buffer.from(`${settings.clientId}:${settings.clientSecret}`).toString("base64");

  const response = await fetch("https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer", {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": authHeader,
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: settings.refreshToken,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error("QB token refresh failed:", body);
    throw new HttpsError("internal", "Failed to refresh QuickBooks token");
  }

  const data = await response.json();

  // Save new tokens to Firestore
  await db.collection("settings").doc("quickbooks").update({
    "tokens.access_token": data.access_token,
    "tokens.refresh_token": data.refresh_token,
    "tokens.expires_in": data.expires_in,
  });

  return {...settings, accessToken: data.access_token, refreshToken: data.refresh_token};
}

function getQBBaseUrl(isProduction) {
  return isProduction
    ? "https://quickbooks.api.intuit.com"
    : "https://sandbox-quickbooks.api.intuit.com";
}

async function createOrGetQBCustomer(settings, billingInfo) {
  const baseUrl = getQBBaseUrl(settings.isProduction);

  // Use entity endpoint instead of query language to avoid injection
  const queryUrl = new URL(`${baseUrl}/v3/company/${settings.realmId}/query`);
  // Properly escape single quotes for QuickBooks query language
  const escapedEmail = billingInfo.email.replace(/'/g, "\\'");
  queryUrl.searchParams.set("query",
    `SELECT * FROM Customer WHERE PrimaryEmailAddr = '${escapedEmail}' MAXRESULTS 1`);

  const queryResponse = await fetch(queryUrl.toString(), {
    headers: {
      "Accept": "application/json",
      "Authorization": `Bearer ${settings.accessToken}`,
    },
  });

  if (queryResponse.ok) {
    const queryData = await queryResponse.json();
    const customers = queryData?.QueryResponse?.Customer;
    if (customers && customers.length > 0) {
      return customers[0].Id;
    }
  }

  // Create new customer
  const customerData = {
    GivenName: billingInfo.firstName,
    FamilyName: billingInfo.lastName,
    DisplayName: `${billingInfo.firstName} ${billingInfo.lastName}`,
    PrimaryEmailAddr: {Address: billingInfo.email},
    PrimaryPhone: {FreeFormNumber: billingInfo.phone},
    BillAddr: {
      Line1: billingInfo.address,
      City: billingInfo.city,
      CountrySubDivisionCode: billingInfo.state,
      PostalCode: billingInfo.zip,
      Country: "USA",
    },
  };

  const createResponse = await fetch(`${baseUrl}/v3/company/${settings.realmId}/customer`, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": `Bearer ${settings.accessToken}`,
    },
    body: JSON.stringify(customerData),
  });

  if (!createResponse.ok) {
    const body = await createResponse.text();
    logger.error("QB customer creation failed:", body);
    throw new HttpsError("internal", "Failed to create QuickBooks customer");
  }

  const responseData = await createResponse.json();
  return responseData.Customer.Id;
}

async function createQBInvoice(settings, order, customerId) {
  const baseUrl = getQBBaseUrl(settings.isProduction);

  const lineItems = order.items.map((item, index) => ({
    LineNum: index + 1,
    Amount: item.price * item.quantity,
    DetailType: "SalesItemLineDetail",
    SalesItemLineDetail: {
      Qty: item.quantity,
      UnitPrice: item.price,
      ItemRef: {name: item.productName || item.name, value: "1"},
    },
    Description: item.productName || item.name,
  }));

  if (order.tax > 0) {
    lineItems.push({
      LineNum: lineItems.length + 1,
      Amount: order.tax,
      DetailType: "SalesItemLineDetail",
      SalesItemLineDetail: {
        Qty: 1,
        UnitPrice: order.tax,
        ItemRef: {name: "Tax", value: "1"},
      },
      Description: "Sales Tax",
    });
  }

  const now = new Date();
  const dueDate = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  const invoiceData = {
    CustomerRef: {value: customerId},
    Line: lineItems,
    TxnDate: now.toISOString().split("T")[0],
    DueDate: dueDate.toISOString().split("T")[0],
    BillEmail: {Address: order.billingInfo.email},
    BillAddr: {
      Line1: order.billingInfo.address,
      City: order.billingInfo.city,
      CountrySubDivisionCode: order.billingInfo.state,
      PostalCode: order.billingInfo.zip,
      Country: "USA",
    },
    CustomerMemo: {value: `Order #${order.id}`},
  };

  const response = await fetch(`${baseUrl}/v3/company/${settings.realmId}/invoice`, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": `Bearer ${settings.accessToken}`,
    },
    body: JSON.stringify(invoiceData),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error("QB invoice creation failed:", body);
    throw new HttpsError("internal", "Failed to create QuickBooks invoice");
  }

  const responseData = await response.json();
  return responseData.Invoice.Id;
}

async function createShipStationOrder(config, order) {
  const apiKey = config.API_KEY;
  const apiSecret = config.API_SK;
  const storeId = config.SHIPSTATION_STORE_ID || "";

  if (!apiKey || !apiSecret) {
    throw new HttpsError("internal", "ShipStation credentials missing");
  }

  const authHeader = "Basic " +
    Buffer.from(`${apiKey}:${apiSecret}`).toString("base64");

  const shipStationOrder = {
    orderNumber: order.id,
    orderDate: order.createdAt,
    orderStatus: "awaiting_shipment",
    customerEmail: order.billingInfo.email,
    billTo: {
      name: `${order.billingInfo.firstName} ${order.billingInfo.lastName}`,
      street1: order.billingInfo.address,
      city: order.billingInfo.city,
      state: order.billingInfo.state,
      postalCode: order.billingInfo.zip,
      country: "US",
      phone: order.billingInfo.phone,
    },
    shipTo: {
      name: `${order.billingInfo.firstName} ${order.billingInfo.lastName}`,
      street1: order.billingInfo.address,
      city: order.billingInfo.city,
      state: order.billingInfo.state,
      postalCode: order.billingInfo.zip,
      country: "US",
      phone: order.billingInfo.phone,
    },
    items: order.items.map((item) => ({
      name: item.productName || item.name,
      quantity: item.quantity,
      unitPrice: item.price,
      sku: item.sku || "",
    })),
    amountPaid: order.total,
    taxAmount: order.tax,
    shippingAmount: 0.0,
    customerNotes: `Order created via mobile app. Reference: ${order.id}`,
    advancedOptions: {storeId},
  };

  const response = await fetch("https://ssapi.shipstation.com/orders/createorder", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": authHeader,
    },
    body: JSON.stringify(shipStationOrder),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error("ShipStation order creation failed:", body);
    throw new HttpsError("internal", "Failed to create ShipStation order");
  }

  const responseData = await response.json();
  return responseData.orderId?.toString() || null;
}

// ─── Create Order (Callable Function) ────────────────────────────────────────

exports.createOrder = onCall({ invoker: "public" }, async (request) => {
  // 1. Authenticate
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be authenticated to create an order");
  }

  const uid = request.auth.uid;
  const {items, billingInfo} = request.data;

  // 1b. Credit-approval gate — only credit-approved customers (or admins) may order.
  //     Blocks unapproved sign-ups from placing orders they haven't been cleared to pay for.
  const orderingUserSnap = await db.collection("users").doc(uid).get();
  const orderingUser = orderingUserSnap.exists ? orderingUserSnap.data() : null;
  if (orderingUser?.creditApproved !== true && orderingUser?.role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Your account is pending credit approval. RD Fresh will review your account, " +
      "and you'll be able to place orders once it's approved.",
    );
  }

  // 2. Validate input
  if (!items || !Array.isArray(items) || items.length === 0) {
    throw new HttpsError("invalid-argument", "Order must contain at least one item");
  }
  if (!billingInfo || !billingInfo.email || !billingInfo.firstName) {
    throw new HttpsError("invalid-argument", "Billing information is required");
  }

  // 3. Server-side price validation -- read prices from products collection
  let subtotal = 0;
  const validatedItems = [];

  for (const item of items) {
    if (!item.productId) {
      throw new HttpsError("invalid-argument", `Item missing productId`);
    }

    const productDoc = await db.collection("products").doc(item.productId).get();
    if (!productDoc.exists) {
      throw new HttpsError("not-found", `Product ${item.productId} not found`);
    }

    const product = productDoc.data();
    const serverPrice = product.price;
    const quantity = Math.max(1, Math.floor(Number(item.quantity) || 1));

    subtotal += serverPrice * quantity;
    validatedItems.push({
      productId: item.productId,
      sku: product.sku || item.sku || "",
      productName: product.name || item.productName || "",
      price: serverPrice,
      image: product.imageUrl || item.image || "",
      quantity,
    });
  }

  // 4. Server-side tax calculation
  const state = (billingInfo.state || "").trim().toLowerCase();
  const isVirginia = state === "virginia" || state === "va";
  const tax = isVirginia ? Math.round(subtotal * 0.053 * 100) / 100 : 0;
  const total = Math.round((subtotal + tax) * 100) / 100;

  // 5. Generate order ID
  const orderId = db.collection("orders").doc().id;
  const createdAt = new Date().toISOString();

  const order = {
    id: orderId,
    userId: uid,
    items: validatedItems,
    billingInfo,
    subtotal,
    tax,
    total,
    status: "pending",
    createdAt,
    customerEmail: billingInfo.email,
  };

  // 6. QuickBooks integration (non-blocking -- order succeeds even if QB fails)
  let quickbooksInvoiceId = null;
  let quickbooksCustomerId = null;
  try {
    let qbSettings = await getQuickBooksSettings();
    qbSettings = await ensureValidQBToken(qbSettings);
    quickbooksCustomerId = await createOrGetQBCustomer(qbSettings, billingInfo);
    quickbooksInvoiceId = await createQBInvoice(qbSettings, order, quickbooksCustomerId);
    order.quickbooksInvoiceId = quickbooksInvoiceId;
    order.status = "processing";
  } catch (e) {
    logger.error("QuickBooks integration failed (non-fatal):", e);
  }

  // 7. ShipStation integration (non-blocking)
  let shipstationOrderId = null;
  let shipStationError = null;
  try {
    const config = await getConfig();
    shipstationOrderId = await createShipStationOrder(config, order);
  } catch (e) {
    shipStationError = e.message || "ShipStation sync failed";
    logger.error("ShipStation integration failed (non-fatal):", e);
  }

  order.shipstationOrderId = shipstationOrderId;
  order.shipStationSyncStatus = shipstationOrderId ? "synced" : "failed";
  order.shipStationError = shipStationError;

  // 8. Save QuickBooks customer ID to user profile
  if (quickbooksCustomerId) {
    try {
      await db.collection("users").doc(uid).update({
        quickbooksCustomerId,
      });
    } catch (e) {
      logger.error("Failed to save QB customer ID to user:", e);
    }
  }

  // 9. Write order to Firestore
  await db.collection("orders").doc(orderId).set(order);

  logger.info(`Order ${orderId} created for user ${uid}`);

  return order;
});

// ─── Approve User (Admin only) ───────────────────────────────────────────────

exports.approveUser = onCall({ invoker: "public" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be authenticated");
  }

  // Verify caller is admin
  const callerDoc = await db.collection("users").doc(request.auth.uid).get();
  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can approve users");
  }

  const {userId} = request.data;
  if (!userId) {
    throw new HttpsError("invalid-argument", "userId is required");
  }

  await db.collection("users").doc(userId).update({status: "approved"});
  logger.info(`User ${userId} approved by admin ${request.auth.uid}`);
  return {success: true};
});

// ─── ShipStation Webhook ────────────────────────────────────────────────────

exports.shipstationWebhook = onRequest({invoker: "public"}, async (req, res) => {
  try {
    const {resource_url: resourceUrl, resource_type: resourceType} = req.body;

    if (resourceType !== "SHIP_NOTIFY" && resourceType !== "ORDER_NOTIFY") {
      return res.status(200).send("Ignored — not a shipping event");
    }

    const config = await getConfig();
    const ssApiKey = config.API_KEY;
    const ssApiSecret = config.API_SK;

    const response = await fetch(resourceUrl, {
      headers: {
        "Authorization": "Basic " +
          Buffer.from(`${ssApiKey}:${ssApiSecret}`).toString("base64"),
      },
    });

    if (!response.ok) {
      logger.error("ShipStation fetch failed", response.status);
      return res.status(500).send("Failed to fetch from ShipStation");
    }

    const data = await response.json();
    const shipments = data.shipments || data.orders || [];

    for (const shipment of shipments) {
      const orderNumber = shipment.orderNumber || shipment.orderKey;
      if (!orderNumber) continue;

      const orderSnapshot = await db.collection("orders")
          .where("id", "==", orderNumber)
          .limit(1)
          .get();

      if (orderSnapshot.empty) {
        logger.warn(`Order not found in Firestore: ${orderNumber}`);
        continue;
      }

      const orderDoc = orderSnapshot.docs[0];
      const orderData = orderDoc.data();
      const now = new Date();
      const deadline = new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000);

      // SHIP_NOTIFY = order shipped -> mark "On the way" (NOT delivered).
      // "delivered" is set only when the customer confirms bag installation.
      await orderDoc.ref.update({
        status: "shipped",
        shippedAt: now.toISOString(),
        bagChangeDeadline: deadline.toISOString(),
        signatureStatus: orderData.signatureStatus || "unsigned",
        remindersSent: 0,
        escalated: false,
      });

      const customerEmail = orderData.customerEmail;
      if (customerEmail) {
        const userSnapshot = await db.collection("users")
            .where("email", "==", customerEmail)
            .limit(1)
            .get();

        if (!userSnapshot.empty) {
          const userId = userSnapshot.docs[0].id;

          await db.collection("notifications").add({
            title: "Your RD Fresh order is on the way!",
            message: `Order #${orderNumber} has shipped. Once it arrives, install the bags in your walk-in cooler and confirm in the app to start your 30-day cycle.`,
            notifyTo: userId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            type: "bag_change_reminder",
            orderId: orderDoc.id,
            readBy: [],
          });
        }
      }

      logger.info(`Order ${orderNumber} marked as delivered, deadline ${deadline.toISOString()}`);
    }

    res.status(200).send("OK");
  } catch (error) {
    logger.error("ShipStation webhook error:", error);
    res.status(500).send("Internal error");
  }
});

// ─── Daily Bag Change Reminder (9 AM Eastern) ──────────────────────────────

exports.dailyBagChangeReminder = onSchedule({
  schedule: "0 9 * * *",
  timeZone: "America/New_York",
  invoker: "public",
}, async () => {
  try {
    const unsignedSnapshot = await db.collection("orders")
        .where("status", "==", "shipped")
        .where("signatureStatus", "==", "unsigned")
        .where("escalated", "==", false)
        .get();

    if (unsignedSnapshot.empty) {
      logger.info("No shipped orders awaiting bag-change confirmation");
      return;
    }

    const now = new Date();

    for (const orderDoc of unsignedSnapshot.docs) {
      const order = orderDoc.data();
      const shipTime = new Date(order.shippedAt || order.deliveredAt);
      const daysSinceDelivery = Math.floor(
          (now - shipTime) / (1000 * 60 * 60 * 24),
      );
      const remindersSent = order.remindersSent || 0;

      const customerEmail = order.customerEmail;
      const userSnapshot = await db.collection("users")
          .where("email", "==", customerEmail)
          .limit(1)
          .get();

      if (userSnapshot.empty) continue;

      const userData = userSnapshot.docs[0].data();
      const userId = userSnapshot.docs[0].id;

      if (remindersSent < 5) {
        await db.collection("notifications").add({
          title: `Day ${remindersSent + 1}: Change Your Bags!`,
          message: `Your RD Fresh bags from order #${order.id || orderDoc.id} shipped ${daysSinceDelivery} days ago. Once they arrive, install them and confirm in the app.`,
          notifyTo: userId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          type: "bag_change_reminder",
          orderId: orderDoc.id,
          readBy: [],
        });

        await orderDoc.ref.update({
          remindersSent: remindersSent + 1,
          lastReminderSentAt: now.toISOString(),
        });

        logger.info(`Sent reminder ${remindersSent + 1}/5 for order ${orderDoc.id}`);
      } else {
        // ESCALATION — 5 days passed, no sign-off
        logger.info(`ESCALATING order ${orderDoc.id} — no sign-off after 5 reminders`);

        const designatedContacts = userData.designatedContacts || [];
        const MIKE_EMAIL = "mike@rdfresh.com";
        const uniqueEmails = [...new Set([
          ...designatedContacts.map((c) => c.email).filter(Boolean),
          MIKE_EMAIL,
        ])];

        if (uniqueEmails.length > 0) {
          const {transporter, from: mailFrom} = await getMailTransporter();

          const customerName = userData.name || userData.email || "Unknown Customer";
          const businessName = userData.businessName || userData.company || customerName;

          await transporter.sendMail({
            from: mailFrom,
            to: uniqueEmails.join(", "),
            subject: `RD Fresh Alert: ${businessName} — Bags Not Changed (${daysSinceDelivery} Days Overdue)`,
            html: `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: #0A6847; padding: 20px; border-radius: 8px 8px 0 0;">
                  <h1 style="color: white; margin: 0; font-size: 20px;">RD Fresh — Bag Change Alert</h1>
                </div>
                <div style="padding: 24px; background: #f9f9f9; border: 1px solid #e0e0e0; border-radius: 0 0 8px 8px;">
                  <p style="font-size: 16px; color: #333;"><strong>${businessName}</strong> has not confirmed bag replacement.</p>
                  <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
                    <tr><td style="padding: 8px; color: #666;">Order Number</td><td style="padding: 8px; font-weight: bold;">#${order.id || orderDoc.id}</td></tr>
                    <tr><td style="padding: 8px; color: #666;">Shipped On</td><td style="padding: 8px; font-weight: bold;">${new Date(order.shippedAt || order.deliveredAt).toLocaleDateString()}</td></tr>
                    <tr><td style="padding: 8px; color: #666;">Days Overdue</td><td style="padding: 8px; font-weight: bold; color: #d32f2f;">${daysSinceDelivery} days</td></tr>
                    <tr><td style="padding: 8px; color: #666;">Contact Email</td><td style="padding: 8px;">${customerEmail}</td></tr>
                  </table>
                  <p style="font-size: 14px; color: #666;">Please follow up with this location to ensure bags are installed.</p>
                </div>
              </div>
            `,
          });

          logger.info(`Escalation email sent to: ${uniqueEmails.join(", ")}`);
        }

        await db.collection("notifications").add({
          title: "Urgent: Bags Still Not Changed",
          message: `It's been ${daysSinceDelivery} days since your bags shipped. Your account manager has been notified. Please install your bags and confirm in the app.`,
          notifyTo: userId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          type: "escalation",
          orderId: orderDoc.id,
          readBy: [],
        });

        await orderDoc.ref.update({
          escalated: true,
          escalatedAt: now.toISOString(),
        });
      }
    }
  } catch (error) {
    logger.error("Daily reminder scheduler error:", error);
  }
});

// ─── Migrate Users to Firebase Auth (one-time) ─────────────────────────────

exports.migrateUsersToFirebaseAuth = onCall({invoker: "public"}, async (request) => {
  const callerEmail = request.auth?.token?.email;
  if (callerEmail !== "devanurag96@gmail.com" && callerEmail !== "mike@rdfresh.com") {
    throw new HttpsError("permission-denied", "Only admin can run migration");
  }

  const usersSnapshot = await db.collection("users").get();
  const results = [];

  for (const doc of usersSnapshot.docs) {
    const userData = doc.data();
    if (!userData.email) continue;

    try {
      try {
        await admin.auth().getUserByEmail(userData.email);
        results.push({email: userData.email, status: "already_exists"});
        continue;
      } catch (e) {
        // User doesn't exist in Auth — create them
      }

      await admin.auth().createUser({
        email: userData.email,
        displayName: userData.name || "",
        password: "TempPass_" + Math.random().toString(36).substring(7),
        emailVerified: true,
      });

      results.push({email: userData.email, status: "created"});
    } catch (err) {
      results.push({email: userData.email, status: "error", error: err.message});
    }
  }

  return {migrated: results.length, results};
});

// ─── Email helper (shared) ───────────────────────────────────────────────────

async function getMailTransporter() {
  const config = await getConfig();
  const user = config.MAIL_USER;
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {user, pass: config.MAIL_PASS},
  });
  return {transporter, from: `"RD Fresh" <${user}>`};
}

// ─── Customer Credit Approval ────────────────────────────────────────────────

async function approvalToken(uid) {
  const config = await getConfig();
  const secret = config.JWT_SECRET || "rdfresh-approval-fallback";
  return crypto.createHmac("sha256", secret).update("approve:" + uid).digest("hex");
}

function safeEqual(a, b) {
  const ab = Buffer.from(String(a), "utf8");
  const bb = Buffer.from(String(b), "utf8");
  if (ab.length !== bb.length) return false;
  return crypto.timingSafeEqual(ab, bb);
}

function escapeHtml(s) {
  return String(s || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
}

function htmlPage(title, bodyHtml) {
  return "<!doctype html><html><head>" +
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" +
    `<title>${escapeHtml(title)}</title></head>` +
    "<body style=\"font-family:-apple-system,Arial,sans-serif;background:#f4f6f4;margin:0;padding:24px;\">" +
    "<div style=\"max-width:480px;margin:0 auto;background:#fff;border-radius:12px;" +
    "overflow:hidden;border:1px solid #e0e0e0;\">" +
    "<div style=\"background:#0A6847;padding:18px 20px;\">" +
    "<h1 style=\"color:#fff;margin:0;font-size:18px;\">RD Fresh</h1></div>" +
    `<div style="padding:24px;color:#222;">${bodyHtml}</div></div></body></html>`;
}

// New signup -> default to NOT credit-approved, and email Mike a review link.
exports.onUserCreated = onDocumentCreated("users/{uid}", async (event) => {
  const uid = event.params.uid;
  const data = (event.data && event.data.data()) || {};

  // Server-controlled gate flag: default new accounts to not-approved.
  if (data.creditApproved === undefined) {
    try {
      await db.collection("users").doc(uid).update({creditApproved: false});
    } catch (e) {
      logger.error("Failed to set default creditApproved:", e);
    }
  }

  // Don't ask Mike to approve admin accounts.
  if (data.role === "admin") return;

  try {
    const token = await approvalToken(uid);
    const reviewUrl =
      `https://us-central1-rd-fresh.cloudfunctions.net/reviewCustomer?uid=${uid}&token=${token}`;
    const name = escapeHtml(data.name || "(no name provided)");
    const email = escapeHtml(data.email || "(no email)");
    const {transporter, from} = await getMailTransporter();
    await transporter.sendMail({
      from,
      to: "mike@rdfresh.com",
      subject: `RD Fresh — New credit request: ${data.name || data.email || uid}`,
      html: `
        <p style="font-size:16px;margin:0 0 12px;">A new customer signed up and needs
        credit approval before they can place orders.</p>
        <table style="width:100%;border-collapse:collapse;margin:8px 0 20px;">
          <tr><td style="padding:6px 0;color:#666;">Name</td>
          <td style="padding:6px 0;font-weight:bold;">${name}</td></tr>
          <tr><td style="padding:6px 0;color:#666;">Email</td>
          <td style="padding:6px 0;font-weight:bold;">${email}</td></tr>
          <tr><td style="padding:6px 0;color:#666;">Signed up</td>
          <td style="padding:6px 0;">${new Date().toLocaleString()}</td></tr>
        </table>
        <a href="${reviewUrl}" style="display:inline-block;background:#0A6847;color:#fff;
        text-decoration:none;padding:12px 22px;border-radius:8px;font-weight:bold;">
        Review &amp; Approve</a>
        <p style="font-size:12px;color:#999;margin:18px 0 0;">Until you approve, this customer
        can browse but cannot place orders.</p>
      `,
    });
    logger.info(`Sent signup approval email to Mike for ${data.email || uid}`);
  } catch (e) {
    logger.error("Failed to send signup approval email:", e);
  }
});

// Mike's approval page. GET renders the review screen; POST performs approve/decline.
exports.reviewCustomer = onRequest({invoker: "public"}, async (req, res) => {
  try {
    const uid = String((req.query && req.query.uid) || (req.body && req.body.uid) || "");
    const token = String((req.query && req.query.token) || (req.body && req.body.token) || "");

    if (!uid || !token) {
      return res.status(400).send(htmlPage("Invalid link", "<p>This link is missing information.</p>"));
    }

    const expected = await approvalToken(uid);
    if (!safeEqual(token, expected)) {
      return res.status(403).send(htmlPage("Invalid link", "<p>This approval link isn't valid.</p>"));
    }

    const snap = await db.collection("users").doc(uid).get();
    if (!snap.exists) {
      return res.status(404).send(htmlPage("Not found", "<p>That customer no longer exists.</p>"));
    }
    const user = snap.data();
    const label = escapeHtml(user.name || user.email || uid);

    if (req.method === "POST") {
      const action = String((req.body && req.body.action) || "");
      if (action === "approve") {
        await db.collection("users").doc(uid).update({
          creditApproved: true,
          approvedAt: new Date().toISOString(),
        });
        await db.collection("notifications").add({
          title: "Account Approved",
          message: "Your RD Fresh account has been approved. You can now place orders in the app.",
          notifyTo: uid,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          type: "account_approved",
          orderId: "",
          readBy: [],
        });
        logger.info(`Customer ${uid} approved via email link`);
        return res.status(200).send(htmlPage("Approved",
            `<p style="font-size:16px;"><b>${label}</b> is approved and can now place orders.</p>`));
      }
      if (action === "decline") {
        await db.collection("users").doc(uid).update({
          creditApproved: false,
          declinedAt: new Date().toISOString(),
        });
        logger.info(`Customer ${uid} declined via email link`);
        return res.status(200).send(htmlPage("Declined",
            `<p style="font-size:16px;"><b>${label}</b> remains blocked from ordering.</p>`));
      }
      return res.status(400).send(htmlPage("Unknown action", "<p>Please use the buttons on the review page.</p>"));
    }

    const already = user.creditApproved === true;
    const statusLine = already ?
      "<p style=\"color:#0A6847;font-weight:bold;\">This customer is already approved.</p>" : "";
    return res.status(200).send(htmlPage("Review customer", `
      ${statusLine}
      <table style="width:100%;border-collapse:collapse;margin:0 0 20px;">
        <tr><td style="padding:6px 0;color:#666;">Name</td>
        <td style="padding:6px 0;font-weight:bold;">${escapeHtml(user.name || "—")}</td></tr>
        <tr><td style="padding:6px 0;color:#666;">Email</td>
        <td style="padding:6px 0;font-weight:bold;">${escapeHtml(user.email || "—")}</td></tr>
        <tr><td style="padding:6px 0;color:#666;">Phone</td>
        <td style="padding:6px 0;">${escapeHtml(user.phone || "—")}</td></tr>
      </table>
      <form method="POST" action="/reviewCustomer" style="display:flex;gap:12px;">
        <input type="hidden" name="uid" value="${escapeHtml(uid)}">
        <input type="hidden" name="token" value="${escapeHtml(token)}">
        <button type="submit" name="action" value="approve" style="flex:1;background:#0A6847;
        color:#fff;border:none;padding:14px;border-radius:8px;font-size:15px;font-weight:bold;
        cursor:pointer;">Approve</button>
        <button type="submit" name="action" value="decline" style="flex:1;background:#fff;
        color:#b00;border:1px solid #b00;padding:14px;border-radius:8px;font-size:15px;
        font-weight:bold;cursor:pointer;">Decline</button>
      </form>
    `));
  } catch (e) {
    logger.error("reviewCustomer error:", e);
    return res.status(500).send(htmlPage("Error", "<p>Something went wrong. Please try again.</p>"));
  }
});
