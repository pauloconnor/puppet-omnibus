class SynapseRecipe < FPM::Cookery::Recipe
  description 'Puppet tools and support gems'

  name 'synapse'
  version '1.0.0'
  source "nothing", :with => :noop

  def build
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc specific_install"
    cleanenv_safesystem "#{destdir}/bin/gem specific_install https://github.com/airbnb/synapse.git"
  end

  def install
  end

end
