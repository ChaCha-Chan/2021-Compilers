# README

- 编译
$ make
- 执行
$ ./proj3< test > test.out
- 基于
flex 2.6.4
bison (GNU Bison) 3.0.4
- 静态语义检查
  - 实现了 (2), (3), (4), (5).
- 和测例的不同
  - 由于lex多算了最后的空行，所以行数会比测例的答案多1。
  - Decls中的变量声明按顺序进入符号表，测例的答案是逆序。
  - 多个main的报错用了MULTI_MAIN的报错打印，和测例的答案不同。

