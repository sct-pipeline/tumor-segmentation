#!/bin/bash
#
# Commands to preprocess the 3 BIDS directories containing the spinal cord tumors
# Before running this script, make sure the parameter files are appropriate
#

sct_run_batch parameters/parameters_astrocytoma.sh process_data.sh
sct_run_batch parameters/parameters_ependymoma.sh process_data.sh
sct_run_batch parameters/paremeters_hemangioblastoma.sh process_data.sh
