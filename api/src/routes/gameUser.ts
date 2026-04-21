import { Hono } from "hono";
import { deleteGameUser } from "../handlers/gameUser/deleteGameUser";
import { createGameUser } from "../handlers/gameUser/createGameByUser";
import { getGameByUser } from "../handlers/gameUser/getUserGame";
import { authMiddleware } from "../middlewares/auth";

const gameRoutes = new Hono();

// 1. Récupérer la bibliothèque de jeux d'un utilisateur (protégé)
gameRoutes.get('/:userId/games', authMiddleware, getGameByUser);

// 2. Ajouter ou mettre à jour un jeu pour un utilisateur (protégé)
gameRoutes.post('/:userId/games', authMiddleware, createGameUser);

// 3. Supprimer un jeu de la bibliothèque d'un utilisateur (protégé)
gameRoutes.delete('/:userId/games/:gameId', authMiddleware, deleteGameUser);

export default gameRoutes;