Lua XOR
=======

This project is simple utility to xor files together.

Demo
====

No demo available yet.

Usage
=====

```
Usage: xor [<option>] <input> [<option>] <input> [[<option>] <inputN>] [...]
Options:
  -m|--master           stop everything at end-of-file of the next file argument
  -w|--write <path>     the read input data will be write in the <path> file
Inputs:
  -                     use stdin as input
  <path>                open and read the <path> file
```

Samples
=======

```
$ ./xor fileA fileB fileC > resultfile
```

```
$ echo 'hello world!' | ./xor --master - /dev/urandom --write part1 > part2
$ ./xor part1 part2
hello world!
```

```
$ echo 'hello world!' | ./xor -m - /dev/urandom -w part1 /dev/urandom -w part2 > part3
$ ./xor part1 part2 part3
hello world!
$ ./xor part*
hello world!
```

License
=======

Code is under the MIT License.

Contact
=======

If you have any ideas, feedback, requests or bug reports, you can reach me at
[tst2005@gmail.com](mailto:tst2005@gmail.com), or via the [github issues](https://github.com/tst2005/xor/issues)


