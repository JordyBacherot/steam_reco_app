import {
  Entity,
  PrimaryColumn,
  ManyToOne,
  JoinColumn
} from "typeorm";
import { Game } from "./Game";

@Entity("NearGames")
export class NearGame {
  @PrimaryColumn()
  id_game!: number;

  @PrimaryColumn()
  id_near_game!: number;

  @ManyToOne(() => Game, (game) => game.nearGamesList)
  @JoinColumn({ name: "id_game" })
  game!: Game;
  
  // Optionally link back to Game for id_near_game if it references the same table
  @ManyToOne(() => Game)
  @JoinColumn({ name: "id_near_game" })
  nearGame!: Game;
}
