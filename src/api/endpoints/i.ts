/**
 * Module dependencies
 */
import User from '../models/user';
import serialize from '../serializers/user';

/**
 * Show myself
 *
 * @param {any} params
 * @param {any} user
 * @param {any} app
 * @param {Boolean} isSecure
 * @return {Promise<any>}
 */
module.exports = (params, user, _, isSecure) => new Promise(async (res, rej) => {
	// Serialize
	res(await serialize(user, user, {
		detail: true,
		includeSecrets: isSecure
	}));

	// Update lastUsedAt
	User.update({ _id: user._id }, {
		$set: {
			last_used_at: new Date()
		}
	});
});
