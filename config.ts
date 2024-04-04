import { config } from "dotenv";

config({
    path: "config.env"
})

export const PRIVATE_KEY = process.env.PRIVATE_KEY || ""