// Shared by badges.typ and mesas.typ: the people list, read with the settings of conteudo.yaml
#let cfg = yaml("conteudo.yaml")

#let navy = rgb("#15152a")
#let muted = rgb("#5d5b70")
#let blue = rgb("#009de0")

// Roles match without case or accents ("Árbitro" = arbitro)
#let norm(s) = {
  let plain = ("á": "a", "à": "a", "â": "a", "ã": "a", "é": "e", "ê": "e", "í": "i", "ó": "o", "ô": "o", "õ": "o", "ú": "u", "ç": "c")
  lower(s.trim()).clusters().map(c => plain.at(c, default: c)).join("")
}

// A role or venue that matches nothing would silently leave someone out, so stop instead
#let role_key(value, who) = {
  for (key, f) in cfg.funcoes {
    if norm(value) == norm(key) or f.nomes.map(norm).contains(norm(value)) { return key }
  }
  panic("função desconhecida \"" + value + "\" para " + who + " (ver funcoes em conteudo.yaml)")
}

#let col = cfg.colunas
#let role_order = cfg.funcoes.keys()

#let pad4(n) = { let s = str(n); "0" * calc.max(0, 4 - s.len()) + s }
#let mesa_key(m) = if m.match(regex("^\d+$")) != none { pad4(int(m)) } else if m == "" { "9999" } else { "9998" + m }

#let people = {
  let out = ()
  for row in csv("input/pessoas.csv", row-type: dictionary) {
    // Strip the BOM that spreadsheet exports put before the first header
    let r = (:)
    for (k, v) in row { r.insert(k.trim("\u{feff}").trim(), v.trim()) }
    let nome = r.at(col.nome)
    if nome == "" { continue }
    let local = r.at(col.local, default: "")
    if local not in cfg.locais {
      panic("local desconhecido \"" + local + "\" para " + nome + " (locais: " + cfg.locais.keys().join(", ") + ")")
    }
    let mesa = upper(r.at(col.mesa, default: ""))
    let mesas = cfg.salas.at(local, default: (:)).at("mesas", default: (:))
    if mesa != "" and mesa not in mesas {
      panic("mesa \"" + mesa + "\" para " + nome + " (mesas em " + local + ": " + mesas.keys().join(", ") + ")")
    }
    let problemas = r.at(col.problemas, default: "")
    if problemas not in ("", "1", "2", "3") {
      panic("problemas \"" + problemas + "\" para " + nome + " (tem de ser 1, 2 ou 3)")
    }
    out.push((nome: nome, funcao: role_key(r.at(col.funcao), nome), local: local, mesa: mesa, problemas: problemas))
  }
  // Two árbitros of one table can't share the same problems
  let seen = (:)
  for p in out.filter(p => p.problemas != "") {
    let key = p.local + " · Mesa " + p.mesa + " · problemas " + p.problemas
    if key in seen { panic(seen.at(key) + " e " + p.nome + " têm ambos " + key) }
    seen.insert(key, p.nome)
  }
  out
}

// Árbitro n corrects the problems with remainder n mod 3: "Problemas 1, 4, 7, 10, …" (3 → 3, 6, 9, …)
#let problems_text(p) = if p.problemas == "" { "Problemas: a atribuir" } else {
  let n = int(p.problemas)
  "Problemas " + range(4).map(i => str(n + 3 * i)).join(", ") + ", …"
}
#let is_arbiter(p) = p.funcao == "arbitro"

#let role_index(p) = pad4(role_order.position(k => k == p.funcao))

// First and last word of the full name
#let split_name(nome) = {
  let words = nome.split(" ").filter(w => w != "")
  (words.first(), if words.len() > 1 { words.last() } else { "" })
}

// "Salão Nobre · Mesa A", or just the venue without a table
#let place_text(p) = cfg.locais.at(p.local) + if p.mesa != "" { " · Mesa " + p.mesa } else { "" }

// Colour means jury table: (cor, texto) of a person's or team's table, sem_mesa for people without one
#let table_style(x) = if x.mesa == "" { cfg.sem_mesa } else { cfg.salas.at(x.local).mesas.at(x.mesa) }
#let table_color(x) = rgb(table_style(x).cor)
#let table_text(x) = rgb(table_style(x).texto)
// Badge background of a person's table: "tic-a", or "sem-mesa"
#let table_key(p) = if p.mesa == "" { "sem-mesa" } else { lower(p.local + "-" + p.mesa) }

// Teams (input/equipas.csv), checked against the rooms in conteudo.yaml
#let tcol = cfg.colunas_equipas

#let category_key(value, who) = {
  for (key, c) in cfg.categorias {
    if norm(value) == norm(key) or c.nomes.map(norm).contains(norm(value)) { return key }
  }
  panic("categoria desconhecida \"" + value + "\" para " + who + " (ver categorias em conteudo.yaml)")
}

#let teams = {
  let out = ()
  let numbers = (:)
  let spots = (:)
  for row in csv("input/equipas.csv", row-type: dictionary) {
    let r = (:)
    for (k, v) in row { r.insert(k.trim("\u{feff}").trim(), v.trim()) }
    let numero = r.at(tcol.numero)
    if numero == "" { continue }
    let who = "equipa " + numero
    let local = r.at(tcol.local)
    if local not in cfg.salas { panic("local desconhecido \"" + local + "\" para " + who + " (salas: " + cfg.salas.keys().join(", ") + ")") }
    let sala = cfg.salas.at(local)
    let fila = r.at(tcol.fila)
    let coluna = r.at(tcol.coluna)
    if fila.match(regex("^\d+$")) == none or int(fila) < 1 or int(fila) > sala.filas {
      panic("fila \"" + fila + "\" fora da sala " + local + " para " + who + " (filas 1–" + str(sala.filas) + ")")
    }
    if coluna.match(regex("^\d+$")) == none or int(coluna) < 1 or int(coluna) > sala.colunas {
      panic("coluna \"" + coluna + "\" fora da sala " + local + " para " + who + " (colunas 1–" + str(sala.colunas) + ")")
    }
    if numero in numbers { panic("equipa " + numero + " repetida") }
    numbers.insert(numero, true)
    let categoria = category_key(r.at(tcol.categoria), who)
    let prefixo = cfg.categorias.at(categoria).at("prefixo", default: "")
    if not numero.starts-with(prefixo) {
      panic(who + " é " + cfg.categorias.at(categoria).titulo + " mas o código não começa por " + prefixo)
    }
    if "categoria" in sala and sala.categoria != categoria {
      panic(who + " é " + cfg.categorias.at(categoria).titulo + " mas a sala " + local + " é " + cfg.categorias.at(sala.categoria).titulo)
    }
    let mesa = upper(r.at(tcol.mesa, default: ""))
    if mesa not in sala.at("mesas", default: (:)) {
      panic("mesa \"" + mesa + "\" para " + who + " (mesas em " + local + ": " + sala.at("mesas", default: (:)).keys().join(", ") + ")")
    }
    let classificacao = r.at(tcol.classificacao, default: "")
    if classificacao not in ("", "1", "2", "3") { panic("classificação \"" + classificacao + "\" para " + who + " (tem de ser 1, 2, 3 ou vazia)") }
    let spot = local + " " + fila + "×" + coluna
    if spot in spots { panic("equipas " + spots.at(spot) + " e " + numero + " no mesmo lugar (" + spot + ")") }
    spots.insert(spot, numero)
    out.push((
      numero: numero,
      escola: r.at(tcol.escola),
      equipa: upper(r.at(tcol.equipa, default: "")),
      categoria: categoria,
      local: local,
      mesa: mesa,
      fila: int(fila),
      coluna: int(coluna),
      alunos: tcol.alunos.map(c => r.at(c, default: "")).filter(n => n != ""),
      professor: r.at(tcol.professor, default: ""),
      classificacao: classificacao,
    ))
  }
  out
}

// "3 × 7": row (from the front) × column
#let spot_text(t) = str(t.fila) + " × " + str(t.coluna)

// Envelopes: one per school, alphabetically; its teams by category and letter, then its teachers.
// A teacher with teams from several schools goes in the envelope of the first one.
#let category_index(t) = pad4(cfg.categorias.keys().position(k => k == t.categoria))
#let teachers = {
  let by_name = (:)
  for t in teams.filter(t => t.professor != "").sorted(key: t => t.escola + category_index(t) + t.equipa) {
    by_name.insert(t.professor, by_name.at(t.professor, default: ()) + (t,))
  }
  by_name
}
#let envelopes = teams.map(t => t.escola).dedup().sorted().map(escola => (
  escola: escola,
  equipas: teams.filter(t => t.escola == escola).sorted(key: t => category_index(t) + t.equipa),
  docentes: teachers.keys().filter(name => teachers.at(name).first().escola == escola).sorted(),
))
#let category(t) = cfg.categorias.at(t.categoria).titulo

// Kinds of school and their usual Portuguese abbreviations, longest first
#let school_kinds = (
  ("Agrupamento de Escolas", "AE"),
  ("Escola Básica e Secundária", "EBS"),
  ("Escola Secundária", "ES"),
  ("Escola Básica", "EB"),
  ("Escola Profissional", "EP"),
)

// Short school names for team sheets and envelope labels ("Escola Secundária Pedro Nunes" → "ES Pedro Nunes");
// certificates and stickers keep the full name
#let school_short(name) = {
  for (long, short) in school_kinds {
    if name.starts-with(long + " ") { return short + name.slice(long.len()) }
  }
  name
}

// The full name split after its kind, where a line break reads naturally:
// ("Escola Secundária", "Pedro Nunes"), or (none, name) for a school with no known kind
#let school_split(name) = {
  for (long, short) in school_kinds {
    if name.starts-with(long + " ") { return (long, name.slice(long.len() + 1)) }
  }
  (none, name)
}

// A4 label sheets, measured in conteudo.yaml (mm): each item drawn by draw(item) in its label, in reading order
#let label_sheets(sheet, items, draw) = {
  for group in items.chunks(sheet.colunas * sheet.linhas) {
    page(paper: "a4", margin: 0pt, {
      for (i, item) in group.enumerate() {
        place(top + left,
          dx: (sheet.margem_esquerda + calc.rem(i, sheet.colunas) * sheet.passo_horizontal) * 1mm,
          dy: (sheet.margem_topo + calc.div-euclid(i, sheet.colunas) * sheet.passo_vertical) * 1mm,
          box(width: sheet.largura * 1mm, height: sheet.altura * 1mm, clip: true,
            stroke: if sheet.contorno { 0.3pt + rgb("#9aa6b8") } else { none }, draw(item)))
      }
    })
  }
}
