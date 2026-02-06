import { Hono } from "hono";
import { deleteGameUser } from "../handlers/gameUser/deleteGameUser";
import { createGameUser } from "../handlers/gameUser/createGameByUser";
import { getGameByUser } from "../handlers/gameUser/getUserGame";

const gameRoutes = new Hono();

// Ici, on définit les routes et on pointe vers les handlers

// 1. Récupérer la bibliothèque de jeux d'un utilisateur
gameRoutes.get('/:userId/games', getGameByUser);

// 2. Ajouter ou mettre à jour un jeu pour un utilisateur
gameRoutes.post('/:userId/games', createGameUser);           // POST /users/1/games

// 3. Supprimer un jeu de la bibliothèque d'un utilisateur
gameRoutes.delete('/:userId/games/:gameId', deleteGameUser); // DELETE /users/1/games/500

export default gameRoutes;