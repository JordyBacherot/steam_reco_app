import {
  Entity,
  PrimaryColumn,
  Column,
  OneToMany
} from "typeorm";
import type { Review } from "./Review";
import type { GameUser } from "./GameUser";
import type { AIRecommendation } from "./AIRecommendation";
import type { NearGame } from "./NearGame";

@Entity("Games")
export class Game {
  @PrimaryColumn()
  id_game!: number;

  @Column()
  name!: string;

  @Column("text", { nullable: true })
  description!: string;

  @Column({ nullable: true })
  image_url!: string;

  @Column("decimal", { precision: 3, scale: 2, nullable: true })
  mean_review!: number;

  @Column({ nullable: true })
  studio!: string;

  @OneToMany("Review", (review: Review) => review.game)
  reviews!: Review[];

  @OneToMany("GameUser", (gameUser: GameUser) => gameUser.game)
  owners!: GameUser[];
  
  @OneToMany("AIRecommendation", (aiReco: AIRecommendation) => aiReco.game)
  aiRecommendations!: AIRecommendation[];

  @OneToMany("NearGame", (nearGame: NearGame) => nearGame.game)
  nearGamesList!: NearGame[];
}
