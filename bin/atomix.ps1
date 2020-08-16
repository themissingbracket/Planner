[CmdletBinding()]
Param(
	[Parameter(Mandatory=$False)]
	[string]$subcommand,

	[Parameter(Mandatory=$False)]
	[string]$exec_command_name,

	[Parameter(Mandatory=$False)]
	[string]$exec_command_args
)

set-strictmode -off

$BASE_COMMAND_NAME="atomix"
$DOCKER_SERVICE_NAME="atomix"
$DOCKER_SYNC_CONTAINER_NAME="atomix-sync"
$OUTPUT_LOG_DIR="tmp"
$OUTPUT_LOG_FILE="$($OUTPUT_LOG_DIR)\output.log"
$GOTO_LOGS_MSG="See $($OUTPUT_LOG_FILE) for error"

filter add_date {"$(Get-Date -Format G): $_"}

function get_is_atomix_container_running() {
	docker-compose ps 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

	if ($LASTEXITCODE -gt 0) {
		return $false
	}

	return Invoke-Expression "docker-compose -f docker-compose.windows.yml ps | Select-String Up 2>&1"
}

function get_is_atomix_container_built() {
	docker-compose ps 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

	if ($LASTEXITCODE -gt 0) {
		return $false
	}

	Invoke-Expression "docker-compose -f docker-compose.windows.yml ps -q $($DOCKER_SERVICE_NAME)"
	
	if ($LASTEXITCODE -gt 0) {
		return $false
	}

	$container_name = Invoke-Expression "docker-compose ps -q $($DOCKER_SERVICE_NAME)"
	
	if (-Not $container_name) {
		return $false
	}

	return Invoke-Expression "docker ps -q --no-trunc -a | Select-String $($container_name)"
}
function sub_status() {
	$docker_result=""

	if (get_is_atomix_container_running) {
		$docker_result="Running"
	} else {
		if (get_is_atomix_container_built) {
			$docker_result="Stopped (built)"
		} else {
			$docker_result="Stopped (unbuilt)"
		}
	}

	Write-Host "
Docker           $docker_result
"
}

function sub_help() {
	Write-Host "
Usage: ${BASE_COMMAND_NAME} <subcommand>
"
	Write-Host "Subcommands:"
	Write-Host "  status    Reports on the status of the Docker container and Docker Sync."
	Write-Host "  start     Builds the Docker container (if needed), runs it and starts Docker Sync."
	Write-Host "  connect   Logs into the Docker container."
	Write-Host "  go        Shortcut for start and connect."
	Write-Host "  stop      Stops the Docker container. Does not destroy it."
	Write-Host "  destroy   Removes the Docker container (requires you to re-build)."
	Write-Host "  exec      Executes a command inside the container. eg. running NPM commands"
	Write-Host "  prune     Prunes Docker and cleans Docker Sync. Prompts to confirm.
"
}

function sub_start() {
	$ERROR_MSG="Failed to start Atomix. Is it already running (atomix status)?"

	Write-Host "Starting Atomix..."

	if (get_is_atomix_container_running) {
		Write-Host "Failed to start Atomix as it is already running."
		exit 1
	}

	if (get_is_atomix_container_built) {
		Write-Host "Already built"
	} else {
		Write-Host "Building Docker (this could take around 5 minutes)..."

		docker-compose -f docker-compose.windows.yml up -d --build  2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

		if ($LASTEXITCODE -gt 0) {
			Write-Host "Failed to build Docker container."
			Write-Host $GOTO_LOGS_MSG
			exit $last_status
		}
	}

	docker-compose -f docker-compose.windows.yml up -d 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

	if ($LASTEXITCODE -gt 0) {
		Write-Host $ERROR_MSG
		Write-Host $GOTO_LOGS_MSG
		exit $last_status
	}

	Write-Host "Atomix has been started successfully. You can now connect to it (atomix connect)."
}

function sub_connect() {
	$ERROR_MSG="Failed to connect to Atomix. Are you sure the container is running (atomix start)?"

	Write-Host "Connecting to Atomix..."

	if (-Not (get_is_atomix_container_running)) {
		Write-Host $ERROR_MSG
		exit 1
	}

	# NOTE: PowerShell redirects all streams to the success steam so we cannot redirect only errors to file (unlike the bash script)
	docker-compose exec $($DOCKER_SERVICE_NAME) bash

	if ($LASTEXITCODE -gt 0) {
		Write-Host $ERROR_MSG
		Write-Host $GOTO_LOGS_MSG
		exit $last_status
	}
}

function sub_go() {
	sub_start
	sub_connect
}

function sub_stop() {
	$ERROR_MSG="Failed to stop Atomix. Are you sure the container is running (atomix status)?"

	Write-Host "Stopping Atomix (this could take 30 seconds)..."

	if (get_is_atomix_container_running) {
		docker-compose stop 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

		if ($LASTEXITCODE -gt 0) {
			Write-Host $ERROR_MSG
			Write-Host $GOTO_LOGS_MSG
			exit $last_status
		}

		Write-Host "Atomix has been stopped."
	} else {
		Write-Host $ERROR_MSG
		exit 1
	}
}

function sub_destroy() {
	$ERROR_MSG="Failed to destroy Atomix. Maybe it has already been destroyed?"

	Write-Host "Destroying Atomix..."

	if (get_is_atomix_container_built) {
		docker-compose down 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

		if ($LASTEXITCODE -gt 0) {
			Write-Host $ERROR_MSG
			Write-Host $GOTO_LOGS_MSG
			exit $last_status
		}

		Write-Host "Successfully destroyed the Docker container and stopped syncing."
	} else {
		Write-Host "Failed to destroy Atomix. It has not been built."
		exit 1
	}
}

function sub_exec() {
	$ERROR_MSG="Failed to execute command in Atomix. Is the container running (atomix status)?"

	Write-Host "Executing command '$($exec_command_name) $($exec_command_args)' in Atomix..."

	if (-Not (get_is_atomix_container_running)) {
		Write-Host $ERROR_MSG
		exit 1
	}

	# NOTE: PowerShell redirects all streams to the success steam so we cannot redirect only errors to file (unlike the bash script)
	# NOTE: Must Invoke-Expression here otherwise args are not passed correctly
	Invoke-Expression "docker-compose exec atomix $($exec_command_name) $($exec_command_args)"

	if ($LASTEXITCODE -gt 0) {
		Write-Host $ERROR_MSG
		Write-Host $GOTO_LOGS_MSG
		exit $last_status
	}

	Write-Host "Done"
}

function sub_prune() {
	Write-Host "This will delete any stopped Docker containers, all unused networks, dangling images and caches."
	Write-Host "If Atomix has stopped ('atomix stop') the container will be deleted."
	Write-Host "You will definitely need to run 'atomix start' again after this.\n"
	$result = Read-Host "Are you sure? (y/n) "

	if ($result -eq "y") {
		Write-Host "Pruning Docker..."

		docker system prune -f 2>&1 | add_date | Out-File -Filepath $OUTPUT_LOG_FILE -append

		if ($LASTEXITCODE -gt 0) {
			Write-Host "Failed to prune Docker."
			Write-Host $GOTO_LOGS_MSG
			exit $last_status
		}

		Write-Host "Docker has been pruned successfully. You will need to run 'atomix start' to rebuild everything."
	} else {
		Write-Host "Prune cancelled."
	}
}

If(!(Test-Path $OUTPUT_LOG_DIR))
{
  New-Item -ItemType Directory -Force -Path $OUTPUT_LOG_DIR
}

if ($subcommand) {
	Invoke-Expression "sub_$($subcommand)"
} else {
	sub_help
}
