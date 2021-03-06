/**
 * Module dependencies
 */
import * as URL from 'url';
const download = require('download');
import $ from 'cafy';
import { validateFileName } from '../../../models/drive-file';
import serialize from '../../../serializers/drive-file';
import create from '../../../common/add-file-to-drive';

/**
 * Create a file from a URL
 *
 * @param {any} params
 * @param {any} user
 * @return {Promise<any>}
 */
module.exports = (params, user) => new Promise(async (res, rej) => {
	// Get 'url' parameter
	// TODO: Validate this url
	const [url, urlErr] = $(params.url).string().$;
	if (urlErr) return rej('invalid url param');

	let name = URL.parse(url).pathname.split('/').pop();
	if (!validateFileName(name)) {
		name = null;
	}

	// Get 'folder_id' parameter
	const [folderId = null, folderIdErr] = $(params.folder_id).optional.nullable.id().$;
	if (folderIdErr) return rej('invalid folder_id param');

	// Download file
	const data = await download(url);

	// Create file
	const driveFile = await create(user, data, name, null, folderId);

	// Serialize
	const fileObj = await serialize(driveFile);

	// Response
	res(fileObj);
});
