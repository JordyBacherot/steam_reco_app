import "reflect-metadata"; // Requis pour TypeORM
import { Hono } from 'hono'
import { AppDataSource } from './database/data-source'
import { seedDatabase } from './database/seed'

/**
 * Point d'entrée de l'API.
 * Initialise la BDD et lance le serveur Hono.
 */

const app = new Hono()

// Initialisation de la connexion BDD au démarrage
AppDataSource.initialize()
  .then(async () => {
    console.log("Data Source has been initialized!")
    
    // Seed automatique si la base est vide (pratique pour Docker)
    await seedDatabase();
  })
  .catch((err) => {
    console.error("Error during Data Source initialization", err)
  })

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

export default app
