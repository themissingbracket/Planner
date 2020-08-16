import { v4 } from 'uuid';
export enum TaskStatusEnum {
	PENDING = 'pending',
	COMPLETED = 'compeleted'
}

export type TaskModelType = {
	id: string | number;
	created_date: Date;
	modified_date?: Date;
	deleted_date?: Date;
	title: string;
	description: string;
	status: TaskStatusEnum;
};

export interface TaskModel {
	// Getters
	getId(): string | number;
	getCreatedDate(): Date;
	getModifiedDate(): Date;
	isDeleted(): boolean;
	getTitle(): string;
	getDescription(): string;
	getStatus(): TaskStatusEnum;
	//Setters
	setModifiedDate(): void;
	deleteTask(): void;
	setStatus(status: TaskStatusEnum): void;
}

export default (
	title: string,
	description?: string,
	status: TaskStatusEnum = TaskStatusEnum.PENDING,
	id: string | number = v4(),
	created_date: Date = new Date(),
	modified_date?: Date,
	deleted_date?: Date
): TaskModel => {
	const task: TaskModelType = {
		id,
		created_date,
		modified_date,
		deleted_date,
		title,
		description,
		status
	};
	// Getters
	const getId = () => task.id;
	const getCreatedDate = () => task.created_date;
	const getModifiedDate = () => task.modified_date;
	const isDeleted = () => !!task.deleted_date;
	const getTitle = () => task.title;
	const getDescription = () => task.description;
	const getStatus = () => task.status;
	//Setters
	const setModifiedDate = () => {
		task.modified_date = new Date();
	};
	const deleteTask = () => {
		task.deleted_date = new Date();
	};
	const setStatus = (status: TaskStatusEnum) => {
		task.status = status;
	};
	const taskModelFactory: TaskModel = Object.freeze({
		getId,
		getCreatedDate,
		getModifiedDate,
		isDeleted,
		getTitle,
		getDescription,
		getStatus,
		setModifiedDate,
		deleteTask,
		setStatus
	});
	return taskModelFactory;
};
