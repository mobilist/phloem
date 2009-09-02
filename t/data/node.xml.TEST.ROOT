<?xml version="1.0" encoding='UTF-8'?>
<!DOCTYPE node SYSTEM "node.dtd">

<!--

 Copyright (C) 2009 Simon Dawson

 This file is part of Phloem.

    Phloem is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Phloem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

-->

<node id="ivor" group="tree" is_root="1">

  <description>
    A dummy root node.
  </description>

  <root host="192.168.0.15" port="9999" />

  <rsync user="simond" />

  <role type="publish" route="root2leaf">
    <directory path="/home/simond/Projects/svn/phloem/branches" />
    <description>
      Publish root2leaf content.
    </description>
  </role>

  <role type="subscribe" route="root2leaf">
    <directory path="/home/simond/Projects/svn/phloem/tags" />
    <filter type="group" value="^lea(ves|f)$" rule="match" />
    <description>
      Subscribe to root2leaf content from matching publisher nodes.
      Currently disabled.
    </description>
  </role>

</node>
