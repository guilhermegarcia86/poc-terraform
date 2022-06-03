resource "local_file" "exemplo" {
  filename = "exemplo.txt"
  content = var.content
}

data "local_file" "conteudo-exemplo" {
  filename = "exemplo.txt"
}

output "data-source-result" {
  value = data.local_file.conteudo-exemplo.content
}

variable "content" {
  type = string
}

output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}