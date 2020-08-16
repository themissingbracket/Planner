import knex from 'knex';
import { config } from 'dotenv';

// Load env from root
config();

const dbconfig = {
	client: 'pg',
	debug: true,
	connection: {
		database: process.env.POSTGRES_DB,
		user: process.env.POSTGRES_USER,
		password: process.env.POSTGRES_PASSWORD,
		host: process.env.POSTGRES_HOST
	},
	migrations: {
		directory: './__database__/migrations'
	}
};

// console.log(config);

interface Users {
	id: number;
	firstname: string;
	lastname: string;
	username: string;
	password: string;
	created_date: Date;
	modified_date: Date;
	deleted_date: Date;
}

const k = knex(dbconfig);

const usersTable = k<Users>('users');

usersTable
	.select('id')
	.then((res) => console.log('users', res))
	.catch((err) => console.log(err));
