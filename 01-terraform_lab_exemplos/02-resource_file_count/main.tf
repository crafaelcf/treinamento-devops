resource "local_file" "aula" {
  count = 10
  filename = "aula${count.index}.txt"
  content = "Olá alunos bem vindo ao terraform ${count.index}.0"
}