import "reflect-metadata";
import { AppDataSource } from "./data-source";
import { User } from "../entities/User";
import { Game } from "../entities/Game";
import { SteamUser } from "../entities/SteamUser";
import { GameUser } from "../entities/GameUser";
import { Review } from "../entities/Review";

/**
 * Script de pré-remplissage (Seed) de la base de données.
 * Exécutable manuellement (`bun seed`) ou au lancement de l'API.
 */
export const seedDatabase = async () => {
  try {
    // Connexion si nécessaire (cas du script autonome)
    if (!AppDataSource.isInitialized) {
       await AppDataSource.initialize();
    }
    console.log("Database connected. Checking for existing data...");

    // Si des utilisateurs existent déjà, on n'ajoute pas les données par défaut.
    const userCount = await AppDataSource.manager.count(User);
    if (userCount > 0) {
        console.log("Data already exists. Skipping seed.");
        return;
    }

    console.log("Seeding...");

    // 1. Création User
    const user = new User();
    user.username = "testuser";
    user.email = "test@example.com";
    user.password = await Bun.password.hash("password123"); // Mot de passe réel haché
    user.have_steamid = true;
    await AppDataSource.manager.save(user);
    console.log("User created:", user.id_user);

    // 2. Création SteamUser
    const steamUser = new SteamUser();
    steamUser.id_steam = "76561198000000000";
    steamUser.username_steam = "SteamTestUser";
    steamUser.user = user;
    steamUser.id_user = user.id_user;
    await AppDataSource.manager.save(steamUser);
    console.log("SteamUser created");

    // 3. Création Jeux
    const game1 = new Game();
    game1.id_game = 10;
    game1.name = "Counter-Strike";
    game1.description = "The classic shooter.";
    await AppDataSource.manager.save(game1);

    const game2 = new Game();
    game2.id_game = 220;
    game2.name = "Half-Life 2";
    game2.description = "Best game ever.";
    await AppDataSource.manager.save(game2);
    console.log("Games created");

    // 4. Création Bibliothèque (Liaison User <-> Game)
    const libraryEntry = new GameUser();
    libraryEntry.user = user;
    libraryEntry.game = game1;
    libraryEntry.nb_hours = 150.5;
    await AppDataSource.manager.save(libraryEntry);
    console.log("Library entry created");

    // 5. Création Review
    const review = new Review();
    review.user = user;
    review.game = game2;
    review.text = "Masterpiece.";
    review.id_game = game2.id_game;
    review.id_user = user.id_user;
    await AppDataSource.manager.save(review);
    console.log("Review created");

    console.log("Seeding complete!");
  } catch (error) {
    console.error("Error during seeding:", error);
    throw error;
  }
};

// Exécution directe si lancé via CLI (`bun run src/database/seed.ts`)
if (import.meta.main) {
    seedDatabase()
        .then(() => process.exit(0))
        .catch(() => process.exit(1));
}
