import { EntitySubscriberInterface, EventSubscriber, InsertEvent, RemoveEvent } from "typeorm";
import { Review } from "../entities/Review";
import { Game } from "../entities/Game";
import 'core-js/actual/promise';

@EventSubscriber()
export class ReviewSubscriber implements EntitySubscriberInterface<Review> {
    
    // On dit au subscriber d'écouter l'entité Review
    listenTo() {
        return Review;
    }

    // Après l'insertion d'une review
    async afterInsert(event: InsertEvent<Review>): Promise<void> {
        await this.updateGameMean(event);
    }

    // Après la suppression d'une review
    async afterRemove(event: RemoveEvent<Review>) {
        await this.updateGameMean(event);
    }

    // La logique de calcul
    private async updateGameMean(event: InsertEvent<Review> | RemoveEvent<Review>) {
        const gameId = event.entity?.id_game || event.entity?.id_game;
        
        if (!gameId) return;

        const reviewRepo = event.manager.getRepository(Review);
        const gameRepo = event.manager.getRepository(Game);

        // 1. Calculer la moyenne (ici on imagine une note sur 5 ou 10)
        const { avg } = await reviewRepo
            .createQueryBuilder("review")
            .select("AVG(review.rating)", "avg") // Remplace 'rating' par ton champ de note si tu en as un
            .where("review.id_game = :gameId", { gameId })
            .getRawOne();

        // 2. Mettre à jour la table Games
        await gameRepo.update(gameId, { 
            mean_review: parseFloat(avg) || 0 
        });
    }
}