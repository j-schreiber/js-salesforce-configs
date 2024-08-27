#! /bin/bash

if [ -z "${!PARAM_EXPORT_VARIABLE_NAME}" ]; then
    echo "No Id exported to ${PARAM_EXPORT_VARIABLE_NAME}. Gracefully exiting..."
    circleci-agent step halt
else
    echo "Subscriber Id ${!PARAM_EXPORT_VARIABLE_NAME} exported to ${PARAM_EXPORT_VARIABLE_NAME}. Continuing ..."
fi