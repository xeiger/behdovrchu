# encoding: utf-8
class StaticPagesController < ApplicationController

  layout 'application'

  def home
    # uvodni stranka pouziva stejny layout, hero se vklada pres content_for :hero
  end

  def programme
  end

  def results
  end

  def gallery
  end

end