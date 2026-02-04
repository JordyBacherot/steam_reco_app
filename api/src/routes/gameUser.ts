import { Hono } from "hono";
import { deleteGameUser } from "../handlers/gameUser/deleteGameUser";
import { createGameUser } from "../handlers/gameUser/createGameByUser";
import { getGameByUser } from "../handlers/gameUser/getUserGame";

const gameRoutes = new Hono();

// Ici, on définit les routes et on pointe vers les handlers
gameRoutes.get('/:userId/games', getGameByUser);
gameRoutes.post('/:userId/games', createGameUser);           // POST /users/1/games
gameRoutes.delete('/:userId/games/:gameId', deleteGameUser); // DELETE /users/1/games/500

export default gameRoutes;