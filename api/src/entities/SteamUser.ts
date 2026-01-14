import {
  Entity,
  PrimaryColumn,
  Column,
  OneToOne,
  JoinColumn
} from "typeorm";
import type { User } from "./User";

@Entity("SteamUsers")
export class SteamUser {
  @PrimaryColumn()
  id_steam!: string; // Steam IDs are usually long strings (64-bit ints)

  @Column()
  id_user!: number;

  @OneToOne("User", (user: User) => user.steamUser)
  @JoinColumn({ name: "id_user" })
  user!: User;

  @Column({ nullable: true })
  level!: number;

  @Column()
  username_steam!: string;

  @Column({ nullable: true })
  image_profil!: string;
}
