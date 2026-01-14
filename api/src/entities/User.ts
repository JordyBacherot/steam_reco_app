import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToOne,
  OneToMany,
  JoinColumn
} from "typeorm";
import type { SteamUser } from "./SteamUser";
import type { ChatbotRecommendation } from "./ChatbotRecommendation";
import type { Review } from "./Review";
import type { GameUser } from "./GameUser";
import type { AIRecommendation } from "./AIRecommendation";

@Entity("Users")
export class User {
  @PrimaryGeneratedColumn()
  id_user!: number;

  @CreateDateColumn()
  created_at!: Date;

  @Column({ unique: true })
  email!: string;

  @Column({ nullable: true })
  profile_img!: string;

  @Column({ unique: true })
  username!: string;

  @Column()
  password!: string;

  @Column({ nullable: true })
  last_connexion!: Date;

  @Column({ default: false })
  have_steamid!: boolean;

  @OneToOne("SteamUser", (steamUser: SteamUser) => steamUser.user)
  steamUser!: SteamUser;

  @OneToMany("ChatbotRecommendation", (reco: ChatbotRecommendation) => reco.user)
  chatbotRecommendations!: ChatbotRecommendation[];

  @OneToMany("Review", (review: Review) => review.user)
  reviews!: Review[];

  @OneToMany("GameUser", (gameUser: GameUser) => gameUser.user)
  library!: GameUser[];
  
  @OneToMany("AIRecommendation", (aiReco: AIRecommendation) => aiReco.user)
  aiRecommendations!: AIRecommendation[];
}
