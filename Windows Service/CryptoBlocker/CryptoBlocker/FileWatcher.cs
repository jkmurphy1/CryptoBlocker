/* 
CryptoBlocker - Windows Service
Copyright (C) 2017  Murphy Solutions

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
namespace CryptoBlocker
{
    class FileWatcher
    {
        private FileSystemWatcher _fileWatcher;

        public FileWatcher()
        {
            _fileWatcher = new FileSystemWatcher(PathLocation());
            _fileWatcher.Created += new FileSystemEventHandler(_fileWatcher_Created);
            _fileWatcher.Deleted += new FileSystemEventHandler(_fileWatcher_Deleted);
            _fileWatcher.Changed += new FileSystemEventHandler(_fileWatcher_Changed);

            _fileWatcher.EnableRaisingEvents = true;
        }

        private string PathLocation()
        {
            string value = String.Empty;
            try
            {
                value = System.Configuration.ConfigurationManager.AppSettings["location"];
                if (value != String.Empty)
                {
                    return value;
                }
            }
            catch (Exception ex)
            {
                //TODO: Implement logging
                
            }
            return value;
        }

        void _fileWatcher_Changed(object sender, FileSystemEventArgs e)
        {
            Logger.Log(String.Format("File Changed: Path:{0}, Name:{1}", e.FullPath, e.Name));
        }
        void _fileWatcher_Deleted(object sender, FileSystemEventArgs e)
        {
            Logger.Log(String.Format("File Deleted: Path:{0}, Name:{1}", e.FullPath, e.Name));
        }
        void _fileWatcher_Created(object sender, FileSystemEventArgs e)
        {
            Logger.Log(String.Format("File Created: Path:{0}, Name:{1}", e.FullPath, e.Name));
        }

    }
}
