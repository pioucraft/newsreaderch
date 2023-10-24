import { Client } from "pg"
import "dotenv/config"
const express = require("express")

const Parser = require('rss-parser');
const parser = new Parser();

const client = new Client({database: "newsreaderch", user: "psql", password: process.env.psql_password})
client.connect().then(() => console.log("connected to the database"));

(async () => {
    console.log((await client.query("SELECT * FROM articles;")).rows)
})();

/*
(async () => {

    let feed = await parser.parseURL('https://www.rts.ch/info/?format=rss/news');
    console.log(feed);
    feed.items = feed.items.reverse()

    feed.items.forEach(async (item) => {
        let d = new Date(item.pubDate)
        await client.query("INSERT INTO articles (title, newspaper, publishedDate, link) VALUES ($1, 'RTS', $2, $3)", [item.title, d.toLocaleString("fr-CH"), item.link])
    });
})();*/
/*
setInterval(async () => {
    let feed = await parser.parseURL('https://www.rts.ch/info/?format=rss/news');
}, 1000*60*15)*/