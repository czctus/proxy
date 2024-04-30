const express = require("express")
const axios = require("axios")

const app = express()
const PORT = 3000

app.post('/proxy', async (req, res) => {
    const { url, method } = req.query;

    if (req.headers["x-perox-proxied"] === "true" || req.headers["x-perox-proxied"] === true) {
        return res.status(429).set('Retry-After', '60').send(`Cannot Proxy ${req.protocol}://${req.hostname}/proxy`)
    }

    if (!url || !method) {
        return res.status(400).send('URL and method parameters are required.');
    }

    if (url.includes('localhost') || url.includes('127.0.0.1') || url.match(/^192\.168\.\d+\.\d+$/)) {
        return res.status(403).send('Access to localhost or private IP addresses is not allowed.');
    }

    if (method === "") {
        return res.status(400).send("Method must be a full string")
    }

    if (typeof method !== "string") {
        return res.status(400).send("Method must be a string");
    }

    if (!['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'LINK'].includes(method.toUpperCase())) {
        return res.status(400).send('Invalid method. Supported methods: GET, POST, PUT, PATCH, DELETE, LINK.');
    }

    try {
        let ip = req.headers['x-forwarded-for'] || req.ip;
        let headers = {
            'X-Perox-Proxied': true,
            'X-Forwarded-For': ip,
            'X-Forwarded-Proto': req.protocol,
            'X-Forwarded-Server': req.hostname
        };

        Object.keys(req.headers).forEach(header => {
            if (header.toLowerCase().startsWith('c-')) {
                headers[header.substring(2)] = req.headers[header];
            }
        });

        const response = await axios({
            method: method.toUpperCase(),
            url: url,
            headers: headers,
            data: req.body,
            rejectUnauthorized: false
        });

        res.status(response.status).send(response.data);
    } catch (error) {
        if (error.response) {
            res.status(error.response.status).send(error.response.data);
        } else {
            res.status(500).send('Internal server error.');
            console.error(error);
        }
    }
});

app.listen(PORT, () => {
    console.log(`Listening on http://localhost:${PORT}`)
})
