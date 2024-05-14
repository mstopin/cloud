import 'dotenv/config'

import express from "express";

(async function main() {
  const app = express();

  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  app.get("/health", (_, res) => {
    res.json({
      health: "ok",
    });
  });

  app.get("/", (_, res) => {
    res.json({
      hello: "world",
    });
  });

  app.listen(Number(process.env.APP_PORT) ?? 3000, () => {
    console.log(`Server is up on ${process.env.APP_PORT ?? 3000}`)
  });
})().catch(console.error);
