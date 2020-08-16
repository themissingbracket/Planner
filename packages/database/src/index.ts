import knex from 'knex';
import { config } from 'dotenv';

// Load env from root
config({
	path: '../../../.env'
});
dotenv.config({
	path: '../../..'
});
console.log(process.env.POSTGRES_DB, 'CONFIG');
const config = {
	client: 'pg',
	debug: true,
	connection: {
		database: 'planner', //process.env.POSTGRES_DB,
		user: 'admin', //process.env.POSTGRES_USER,
		password: 'eTYrOSidITEM', //process.env.POSTGRES_PASSWORD,
		port: 5333
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

const k = knex(config);

const usersTable = k<Users>('users');

usersTable
	.select('id')
	.then((res) => console.log('users', res))
	.catch((err) => console.log(err));
