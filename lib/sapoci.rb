# Copyright (C) 2010 Oliver Eilhard
#
# This SAP OCI library is freely distributable under 
# the terms of an MIT-style license.
# See COPYING or http://www.opensource.org/licenses/mit-license.php.

# This library is for parsing and emitting shopping cart data and
# behavior in SAP OCI style.

module SAPOCI
  VERSION_40    = "4.0"
  
  autoload :CoreExt,      'sapoci/core_ext.rb'
  autoload :Document,     'sapoci/document.rb'
  autoload :Item,         'sapoci/item.rb'
end
