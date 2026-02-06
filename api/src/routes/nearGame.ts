import { Hono } from 'hono';
import { getNearGame } from '../handlers/nearGame/getNearGame';
import { deleteNearGame } from '../handlers/nearGame/deleteNearGame';
import { addNearGame } from '../handlers/nearGame/addNearGame';

const nearGameRoutes = new Hono();

// Ici, on est déjà "dans" le contexte des jeux

// 1. Récupération des jeux similaires
nearGameRoutes.get('/:id', getNearGame);

// 2. Ajout de recommandation
nearGameRoutes.post('/', addNearGame);

// 3. Suppression d'une liaison
nearGameRoutes.delete('/:id/:nearId', deleteNearGame);

export default nearGameRoutes;