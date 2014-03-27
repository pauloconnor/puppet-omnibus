class SynapseRecipe < FPM::Cookery::Recipe
  description 'Puppet tools and support gems'

  name 'synapse'
  version '1.0.0'
  source "https://github.com/airbnb/synapse", :with => :git,

  def build
    cleanenv_safesystem "#{destdir}/bin/gem build *.gemspec"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc *,gem"
  end

  def install
  end

end
