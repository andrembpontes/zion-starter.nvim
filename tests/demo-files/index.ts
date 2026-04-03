type User = {
  id: number
  name: string
}

export function greet(u: User): string {
  return `Hello, ${u.name}`
}
