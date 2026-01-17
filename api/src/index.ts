import app from "./app";
import { initializeDatabase, AppDataSource } from "./database/data-source";
import { seedDatabase } from "./database/seed";

/**
 * ============================================================================
 * POINT D'ENTRÉE DU SERVEUR (Server Entry Point)
 * ============================================================================
 * Ce script est responsable de :
 * 1. Initialiser la connexion à la base de données.
 * 2. Lancer le script de seed (si nécessaire).
 * 3. Démarrer le serveur HTTP via `Bun.serve`.
 * 4. Gérer l'arrêt propre (Graceful Shutdown).
 */

async function startServer() {
  try {
    // 1. Initialisation de la BDD
    await initializeDatabase();

    // 2. Auto-Seed 
    // Si la connexion est établie et que la base est vide, on la remplit.
    if (AppDataSource.isInitialized) {
        await seedDatabase().catch(err => console.error("Auto-seed failed:", err));
    }

    // 3. Gestion de l'arrêt propre (Graceful Shutdown)
    // Ferme la connexion BDD proprement quand on arrête le conteneur ou le processus.
    const shutdown = async () => {
      console.log("Shutting down...");
      if (AppDataSource.isInitialized) {
          await AppDataSource.destroy();
          console.log("Database connection closed.");
      }
      process.exit(0);
    };

    // Écoute les signaux d'arrêt du système
    process.on("SIGINT", shutdown);  // Ctrl+C
    process.on("SIGTERM", shutdown); // docker stop
    
    console.log(`Server is starting...`);

  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

// Lancement de la logique de démarrage
startServer();

// Export default pour Bun.serve
// Bun utilise cet objet pour configurer et lancer le serveur HTTP natif.
export default {
  port: process.env.PORT || 3000,
  fetch: app.fetch
};
