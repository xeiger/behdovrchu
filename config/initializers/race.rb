# Udaje o aktualnim rocniku. Jedine misto, ktere se meni pri priprave noveho rocniku
# (kategorie v propozicich a validace roku narozeni se z toho dopocitaji).
RACE = {
  edition: 56,
  year: 2026,
  date: Date.new(2026, 12, 5),              # vzdy prvni sobota v prosinci
  payment_deadline: Date.new(2026, 12, 3),  # ctvrtek pred zavodem
  fee: 250,
  fee_late: 300,
  capacity: 300,
  # :soon     = prihlasovani brzy spustime
  # :open     = formular je otevreny
  # :closed   = on-line prihlasovani zastaveno, prihlasit se lze na miste
  # :finished = zavod probehl, na webu jsou vysledky
  registration: :open,
  results_pdf: false,                       # true az budou nahrana PDF s vysledky
}.freeze
