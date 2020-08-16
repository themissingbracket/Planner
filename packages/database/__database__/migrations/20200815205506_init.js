/* eslint-disable @typescript-eslint/no-var-requires */
const Knex = require('knex');
const taskTable = require('../factories/taskTable');
const userTable = require('../factories/userTable');

/**
 *
 * @param {Knex} knex
 */
exports.up = async (knex) => {
	await userTable.up(knex);
	await taskTable.up(knex);
};
/**
 *
 * @param {Knex} knex
 */
exports.down = async (knex) => {
	await taskTable.down(knex);
	await userTable.down(knex);
};
