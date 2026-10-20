module RaceHelper
  CZECH_MONTHS = %w[ledna února března dubna května června července srpna září října listopadu prosince].freeze

  def short_date(date)
    date.strftime('%-d.%-m.%Y')
  end

  def czech_date(date)
    "#{date.day}. #{CZECH_MONTHS[date.month - 1]} #{date.year}"
  end

  # dalsi rocnik: prvni sobota v prosinci nasledujiciho roku
  def next_race_date
    d = Date.new(RACE[:year] + 1, 12, 1)
    d += 1 until d.saturday?
    d
  end

  def nav_items
    a = params[:action]
    [
      ['Propozice',           programme_page_path, a == 'programme'],
      ['Přihláška',           new_entrant_path,    %w[new create].include?(a)],
      ['Seznam přihlášených', entrants_path,       a == 'index'],
      ['Výsledky',            results_page_path,   a == 'results'],
      ['Galerie',             gallery_page_path,   a == 'gallery'],
    ]
  end
end
