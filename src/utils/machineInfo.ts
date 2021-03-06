import * as os from 'os';
import Logger from './logger';

export default class {
	static show(): void {
		const totalmem = (os.totalmem() / 1024 / 1024 / 1024).toFixed(1);
		const freemem = (os.freemem() / 1024 / 1024 / 1024).toFixed(1);
		let logger = new Logger('Machine');
		logger.info(`Hostname: ${os.hostname()}`);
		logger.info(`Platform: ${process.platform}`);
		logger.info(`Architecture: ${process.arch}`);
		logger.info(`Node.js: ${process.version}`);
		logger.info(`CPU: ${os.cpus().length}core`);
		logger.info(`MEM: ${totalmem}GB (available: ${freemem}GB)`);
	}
}
