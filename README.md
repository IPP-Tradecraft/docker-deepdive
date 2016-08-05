# Latest version

Current stable release: v1.0.3

# Introduction

Deepdive analytics engine (http://deepdive.stanford.edu/)[http://deepdive.stanford.edu/]
in a docker container.

Usage is 


# Running the examples

TODO: Lots to write here,

### Important Note

The container configures postgresql to only bind on localhost:5432.
Which means that  we have to ensure all `db.url` for examples 
should be postgres://deepdiver@localhost:5432/  instead of
postgres://deepdiver@$HOSTNAME:5432/

So instead of:

	<strike>`echo "postgresql://$USER@$HOSTNAME:5432/deepdive_spouse_$USER" >db.url`</strike>

Do:

	`echo "postgresql://deepdiver@localhost:5432/deepdive_spouse_deepdiver" >db.url`


