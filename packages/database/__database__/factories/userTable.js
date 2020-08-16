/* eslint-disable @typescript-eslint/no-var-requires */
const Knex = require('knex');
const addDefaults = require('../common/addDefaults');
const { USERS } = require('../common/TableNames');
/**
 *
 * @param {Knex} knex
 */
function buildUserTable(knex) {
	return knex.schema.createTable(USERS, (table) => {
		addDefaults(table);
		table.string('username').notNullable().unique();
		table.string('email').notNullable().unique();
		table.string('password').notNullable();
		table.string('firstname');
		table.string('lastname');
	});
}
/**
 *
 * @param {Knex} knex
 */
function dropUserTable(knex) {
	return knex.schema.dropTable(USERS);
}
const usertable = {
	up: buildUserTable,
	down: dropUserTable
};

module.exports = usertable;
