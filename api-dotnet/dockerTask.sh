imageName="stevelasker/api-dotnet"
projectName="apidotnet"
serviceName="api-dotnet"
containerName="${projectName}_${serviceName}_1"
publicPort=5000
isWebProject=true
url="http://localhost:$publicPort/api/hello"
runtimeID="debian.8-x64"
framework="netcoreapp1.0"

# Kills all running containers of an image and then removes them.
cleanAll () {
    # List all running containers that use $imageName, kill them and then remove them.
    docker kill $(docker ps -a | awk '{ print $1,$2 }' | grep $imageName | awk '{ print $1}') > /dev/null 2>&1;
    docker rm $(docker ps -a | awk '{ print $1,$2 }' | grep $imageName | awk '{ print $1}') > /dev/null 2>&1;
}

# Builds the Docker image.
buildImage () {
    if [[ -z $ENVIRONMENT ]]; then
       ENVIRONMENT="debug"
    fi

    dockerFileName="Dockerfile"
    taggedImageName="$imageName"
    if [[ $ENVIRONMENT != "release" ]]; then
        dockerFileName="Dockerfile.$ENVIRONMENT"
        taggedImageName="$imageName:$ENVIRONMENT"
    fi

    if [[ ! -f $dockerFileName ]]; then
      echo "$ENVIRONMENT is not a valid parameter. File '$dockerFileName' does not exist."
    else
      echo "Building the project ($ENVIRONMENT)."
      pubFolder="bin/$ENVIRONMENT/$framework/publish"
      dotnet publish -f $framework -r $runtimeID -c $ENVIRONMENT -o $pubFolder

      echo "Building the image $imageName ($ENVIRONMENT)."
      docker build -f "$pubFolder/$dockerFileName" -t $taggedImageName $pubFolder
    fi
}

# Runs docker-compose.
compose () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  composeFileName="docker-compose.yml"
  if [[ $ENVIRONMENT != "release" ]]; then
      composeFileName="docker-compose.$ENVIRONMENT.yml"
  fi

  if [[ ! -f $composeFileName ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
  else
    echo "Running compose file $composeFileName"
    docker-compose -f $composeFileName -p $projectName kill
    docker-compose -f $composeFileName -p $projectName up -d
  fi
}

startDebugging () {
    echo "Running on $url"

    containerId=$(docker ps -f "name=$containerName" -q -n=1)
    if [[ -z $containerId ]]; then
      echo "Could not find a container named $containerName"
    else
      docker exec -i $containerId /clrdbg/clrdbg --interpreter=mi
    fi

}

openSite () {
    printf 'Opening site'
    until $(curl --output /dev/null --silent --head --fail $url); do
      printf '.'
      sleep 1
    done

    # Open the site.
    open $url
}

# Shows the usage for the script.
showUsage () {
    echo "Usage: dockerTask.sh [COMMAND] (ENVIRONMENT)"
    echo "    Runs build or compose using specific environment (if not provided, debug environment is used)"
    echo ""
    echo "Commands:"
    echo "    build: Builds a Docker image ('$imageName')."
    echo "    compose: Runs docker-compose."
    echo "    clean: Removes the image '$imageName' and kills all containers based on that image."
    echo "    composeForDebug: Builds the image and runs docker-compose."
    echo "    startDebugging: Finds the running container and starts the debugger inside of it."
    echo ""
    echo "Environments:"
    echo "    debug: Uses debug environment for build and/or compose."
    echo "    release: Uses release environment for build and/or compose."
    echo ""
    echo "Example:"
    echo "    ./dockerTask.sh build debug"
    echo ""
    echo "    This will:"
    echo "        Build a Docker image named $imageName using debug environment."
}

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
      "compose")
             ENVIRONMENT=$2
             compose
             if [[ $isWebProject = true ]]; then
               openSite
             fi
             ;;
      "composeForDebug")
             ENVIRONMENT=$2
             export REMOTE_DEBUGGING=1
             buildImage
             compose
             ;;
      "startDebugging")
             startDebugging
             ;;
      "build")
             ENVIRONMENT=$2
             buildImage
             ;;
      "clean")
             cleanAll
             ;;
      *)
             showUsage
             ;;
  esac
fi