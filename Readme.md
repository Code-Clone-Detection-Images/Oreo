# Oreo

Run [Oreo](https://github.com/Mondego/oreo) on a supplied folder.

**Build** using the [`makefile`](makefile).
**Run** using the [run-script](run.sh) script, supply it with the project folder.

> As only the `pwd` (current working directory) will be mounted automatically, you can not specify files/folders located in upper levels.

Example:

```bash
make
./run.sh java-small
```
