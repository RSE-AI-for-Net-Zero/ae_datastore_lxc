#!/bin/bash

# Delete old containers
for i in rabbitmq postgresql redis opensearch; do
	if incus list -f csv | grep "rdm-$i" | grep -q "RUNNING"; then
		echo "Stopping rdm-$i"
		incus stop rdm-$i
	fi
	if incus list -f csv | grep -q "rdm-$i"; then
		echo "Deleting rdm-$i"
		incus delete rdm-$i
	fi
done


