/* eslint-disable @typescript-eslint/no-var-requires */
const Knex = require('knex');
const addDefaults = require('../common/addDefaults');
const { USERS, TASKS } = require('../common/TableNames');

/**
 *
 * @param {Knex} knex
 */
function buildTaskTable(knex) {
	return knex.schema.createTable(TASKS, (table) => {
		addDefaults(table);
		table.string('title').notNullable();
		table.string('description');
		table.integer('user_id').notNullable();
		table.foreign('user_id').references('id').inTable(USERS);
		table.string('status');
	});
}
/**
 *
 * @param {Knex} knex
 */
function dropTaskTable(knex) {
	return knex.schema.dropTable(TASKS);
}
const taskTable = {
	up: buildTaskTable,
	down: dropTaskTable
};
module.exports = taskTable;
