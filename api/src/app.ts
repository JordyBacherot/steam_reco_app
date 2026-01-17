import "reflect-metadata";

import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import type { ContentfulStatusCode } from "hono/utils/http-status";

import { cors } from "hono/cors";
import { logger as honoLogger } from "hono/logger";
import { prettyJSON } from "hono/pretty-json";
import { secureHeaders } from "hono/secure-headers";
import { trimTrailingSlash } from "hono/trailing-slash";
import authRouter from "./routes/auth";
import recommendationRoutes from "./routes/recommendation";

/**
 * ============================================================================
 * CONFIGURATION DE L'APPLICATION HONO
 * ============================================================================
 * Ce fichier configure l'instance principale de l'application Hono.
 * Il définit les middlewares globaux, monte les routeurs et gère les erreurs.
 */

const app = new Hono();

// --------------------------------------------------------
// MIDDLEWARES GLOBAUX
// --------------------------------------------------------

// Logger : Affiche les logs des requêtes dans la console
app.use("*", honoLogger());

// Secure Headers : Ajoute des en-têtes de sécurité 
app.use(
  "*",
  secureHeaders({
    crossOriginResourcePolicy: "cross-origin"
  })
);

// Pretty JSON : Formatte le JSON pour qu'il soit lisible (utile en dev)
app.use("*", prettyJSON());

// CORS : Gestion des accès cross-origin
app.use(
  "*",
  cors({
    origin: "*", // TODO : À sécuriser en production (mettre l'URL du front)
    allowMethods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
    credentials: true
  })
);

// Nettoyage des URL : Supprime le slash final (ex: /users/ -> /users)
app.use("*", trimTrailingSlash());

// --------------------------------------------------------
// ROUTES DE BASE
// --------------------------------------------------------

app.get("/", async (c) => {
  return c.json({ success: true, message: `Steam Reco APP API` }, 200);
});

// Route de santé (Health Check) utilisée par Docker et les load balancers
app.get("/health", async (c) => {
  return c.json(
    {
      success: true,
      status: "healthy",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      uptime: Math.floor(process.uptime()) + "s"
    },
    200
  );
});

// MONTAGE DES ROUTEURS (Sub-Apps)
app.route("/auth", authRouter);

app.route("/recommendations", recommendationRoutes);


// GESTION DES ERREURS
// 404 - Not Found
app.notFound((c) => {
  return c.json(
    {
      success: false,
      error: "Not Found",
      message: "Route not found",
      timestamp: new Date().toISOString()
    },
    404
  );
});

// Gestionnaire d'erreurs global (attrape les throw HTTPException et les crashs)
app.onError((error: Error, c) => {
  // Si c'est une erreur HTTP connue (400, 401, etc.)
  if (error instanceof HTTPException) {
    return c.json(
      { success: false, message: error.message ?? "An error has occurred" },
      error.getResponse().status as ContentfulStatusCode
    );
  }
  // Sinon, c'est un crash serveur inattendu (500)
  console.error("Global Error:", error);
  return c.json({ success: false, message: "An error has occurred" }, 500);
});

export default app;
