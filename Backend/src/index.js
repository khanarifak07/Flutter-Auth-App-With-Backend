import dotenv from "dotenv";
import { app } from "./app.js";
import dbConnect from "./db/db.js";
dotenv.config({ path: "./env" });

dbConnect()
  .then(() => {
    app.on("error", (error) => {
      console.log("Error while connecting to server ", error);
    });
    app.listen(process.env.PORT || 3000, () => {
      console.log(`Server is running at port ${process.env.PORT}`);
    });
  })
  .catch((err) => {
    console.log("Something went wrong while conecting", err);
  });
