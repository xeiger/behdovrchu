class EntrantMailer < ActionMailer::Base
  default from: "behdovrchu@email.cz"

  def registration(entrant)
    @subject = "BĚH DO VRCHU - Informace k platbě startovného "
    @to = entrant.to_mail
    @body = "Dobrý den,\n\n obdrželi jsme Vaši přihlášku a zasíláme Vám informace k zaplacení startovného:\n\nČíslo účtu: xxxxxxxx/xxxx\nvariabilní symbol: #{entrant.variable_symbol}\nČástka: 100 Kč\n\nPřipsání peněz na náš účet si můžete zkontrolovat na našem webu.\n\nDěkujeme a přejeme kvalitní trénink.\n\nTým BeskydSki\nwww.beskydski.cz"

    mail(to: @to, subject: @subject, body: @body) unless @to.blank?
  end

end
