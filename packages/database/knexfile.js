/* eslint-disable @typescript-eslint/no-var-requires */
// Set in the docker compose file
const {
	POSTGRES_PASSWORD,
	POSTGRES_USER,
	POSTGRES_DB,
	POSTGRES_HOST
} = process.env;

console.log({ POSTGRES_PASSWORD, POSTGRES_USER, POSTGRES_DB });
// Update with your config settings.

module.exports = {
	development: {
		client: 'pg',
		debug: true,
		connection: {
			database: process.env.POSTGRES_DB,
			user: process.env.POSTGRES_USER,
			password: process.env.POSTGRES_PASSWORD,
			host: POSTGRES_HOST
		},
		migrations: {
			directory: './__database__/migrations'
		}
	}
};
