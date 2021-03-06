import * as express from 'express';
import * as bcrypt from 'bcryptjs';
import rndstr from 'rndstr';
import recaptcha = require('recaptcha-promise');
import User from '../models/user';
import { validateUsername, validatePassword } from '../models/user';
import serialize from '../serializers/user';
import config from '../../conf';

recaptcha.init({
	secret_key: config.recaptcha.secretKey
});

export default async (req: express.Request, res: express.Response) => {
	// Verify recaptcha
	// ただしテスト時はこの機構は障害となるため無効にする
	if (process.env.NODE_ENV !== 'test') {
		const success = await recaptcha(req.body['g-recaptcha-response']);

		if (!success) {
			res.status(400).send('recaptcha-failed');
			return;
		}
	}

	const username = req.body['username'];
	const password = req.body['password'];
	const name = '名無し';

	// Validate username
	if (!validateUsername(username)) {
		res.sendStatus(400);
		return;
	}

	// Validate password
	if (!validatePassword(password)) {
		res.sendStatus(400);
		return;
	}

	// Fetch exist user that same username
	const usernameExist = await User
		.count({
			username_lower: username.toLowerCase()
		}, {
			limit: 1
		});

	// Check username already used
	if (usernameExist !== 0) {
		res.sendStatus(400);
		return;
	}

	// Generate hash of password
	const salt = bcrypt.genSaltSync(8);
	const hash = bcrypt.hashSync(password, salt);

	// Generate secret
	const secret = '!' + rndstr('a-zA-Z0-9', 32);

	// Create account
	const account = await User.insert({
		token: secret,
		avatar_id: null,
		banner_id: null,
		created_at: new Date(),
		description: null,
		email: null,
		followers_count: 0,
		following_count: 0,
		links: null,
		name: name,
		password: hash,
		posts_count: 0,
		likes_count: 0,
		liked_count: 0,
		drive_capacity: 1073741824, // 1GB
		username: username,
		username_lower: username.toLowerCase(),
		profile: {
			bio: null,
			birthday: null,
			blood: null,
			gender: null,
			handedness: null,
			height: null,
			location: null,
			weight: null
		}
	});

	// Response
	res.send(await serialize(account));

	// Create search index
	if (config.elasticsearch.enable) {
		const es = require('../../db/elasticsearch');
		es.index({
			index: 'misskey',
			type: 'user',
			id: account._id.toString(),
			body: {
				username: username
			}
		});
	}
};
