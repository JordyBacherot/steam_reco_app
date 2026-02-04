import { Hono } from 'hono';
import { getNearGame } from '../handlers/nearGame/getNearGame';
import { deleteNearGame } from '../handlers/nearGame/deleteNearGame';
import { addNearGame } from '../handlers/nearGame/addNearGame';

const nearGameRoutes = new Hono();

// Ici, on est déjà "dans" le contexte des jeux
nearGameRoutes.get('/:id', getNearGame);
nearGameRoutes.post('/', addNearGame);
nearGameRoutes.delete('/:id/:nearId', deleteNearGame);

export default nearGameRoutes;