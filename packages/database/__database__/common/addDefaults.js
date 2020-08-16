module.exports = (table) => {
	table.increments('id').primary();
	table.date('created_date').nullable();
	table.date('modified_date');
	table.date('deleted_date');
};
